function [mod_P, re_message]=decode_skewed_histogram_shifting(P,half)
[n m]=size(P);
%border side information extraction
message_length_max=floor(log2(n*m));
b_side_info = P(1:message_length_max+2);
bi_message_length=bi2de(mod(b_side_info(1:end-2),2));
pred_method=bi2de(mod(b_side_info(end-1:end),2));


LC=zeros(n,m);
counter=0;
for i1=2:n-1
    for j1=2:m-1
        if rem(i1+j1,2)==half
            counter=counter+1;
            W=P(i1,j1-1);N=P(i1-1,j1);E=P(i1,j1+1);S=P(i1+1,j1);
            LC(i1,j1)=abs(N-E)+abs(E-S)+abs(S-W)+abs(W-N)+abs(N-S)+abs(E-W);
        end
    end
end
pixel_profile=zeros(counter,7);
counter=0;

for i1=2:n-1
    for j1=2:m-1
        if rem(i1+j1,2)==half
            counter=counter+1;
            W=P(i1,j1-1);N=P(i1-1,j1);E=P(i1,j1+1);S=P(i1+1,j1);
            W_LC=LC(i1,j1)+LC(i1-1,j1-1)+LC(i1-1,j1+1)+LC(i1+1,j1-1)+LC(i1+1,j1+1);
            pixel_profile(counter,:)=[W_LC P(i1,j1) N W S E (j1-1)*n+i1];
        end
    end
end
sorted_pixel_profile=sortrows(pixel_profile,1);

if half == 1
    message_length=bi_message_length-round(bi_message_length/2);
else
    message_length=round(bi_message_length/2);
end

counter=length(sorted_pixel_profile);
location=zeros(1,counter);
mod_P=P;
ec=0;
final_set=0;
temp=zeros(1,counter);
for i1=1:counter
    current_set=sorted_pixel_profile(i1,:);
    loc_y=current_set(7);
    if loc_y > message_length_max+2
        %Prediction
        if pred_method==1
            sorted_pixels=sort(current_set(3:6),'descend');
            Pred_h=round(sum(sorted_pixels(1)));
            Pred_l=round(sum(sorted_pixels(4)));
        elseif pred_method==2
            sorted_pixels=sort(current_set(3:6),'descend');
            Pred_h=round(sum(sorted_pixels(1:2))/2);
            Pred_l=round(sum(sorted_pixels(3:4))/2);
        elseif pred_method==3
            sorted_pixels=sort(current_set(3:6),'descend');
            Pred_h=round(sum(sorted_pixels(1:3))/3);
            Pred_l=round(sum(sorted_pixels(2:4))/3);
        elseif pred_method==4
            Pred_h=round(sum(current_set(3:6))/4);
            Pred_l=Pred_h-1;
        else 
            pause
        end
        if Pred_h==Pred_l
            Pred_l=Pred_l-1;
        end
        
        pe=mod_P(loc_y)-Pred_l;
        pixel=mod_P(loc_y);
        if message_length >= ec+1
            [ec, pixel, re_m]=prediction(ec,pixel,pe,-1);
            pe=pixel-Pred_h;
            if isempty(re_m)==0
                re_message(ec)=re_m;
            end
            if message_length ~= ec
                [ec, pixel, re_m]=prediction(ec,pixel,pe,1);
                if isempty(re_m)==0
                    re_message(ec)=re_m;
                end
            else
                [ec, pixel, re_m]=prediction(ec,pixel,pe,1);
                if message_length ~= ec
                    ec=ec-1;
                end
            end
        else
            break
        end
        location(i1)=loc_y;
        temp(i1)=pixel;
        final_set=i1;
    end
end
if final_set~=0
    mod_P(location(1:final_set))=temp(1:final_set);
end

end

function [ec, pixel,re_m]=prediction(ec,pixel,pe,direction)
re_m=[];
if direction ==1
    if pe == 0
        ec=ec+1;
        re_m=0;
    elseif pe == 1
        ec=ec+1;
        re_m=1;
        pixel=pixel-1;
    elseif pe > 1
        pixel=pixel-1;
    end
else
    if pe == 0
        ec=ec+1;
        re_m=0;
    elseif pe == -1
        ec=ec+1;
        re_m=1;
        pixel=pixel+1;
    elseif pe < -1
        pixel=pixel+1;
    end
end
end
