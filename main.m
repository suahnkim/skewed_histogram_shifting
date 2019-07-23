function main
rng(0)
original_image=double(rgb2gray(imread('4.2.03.tiff')));
%Preprocess
[n m]=size(original_image);
message_length_max=floor(log2(n*m));
length_loc_map_max=ceil(log2((n-2)*(m-2)));

message_length=5000;
original_message=randi([0,1],1,message_length);
[P location_map location_map_length]=preproces_image(original_image);
border_pixel=mod(P(1:message_length_max+2),2);

message=[border_pixel location_map_length location_map original_message];
total_message_length=length(message);
result=zeros(1,3);
%Encoding
for mode=1:3
    re_P=P;
    tic
    %Preprocess border pixels
    bi_message_length=de2bi(total_message_length,message_length_max);
    re_P(1:message_length_max+2)=bitxor(bitxor(P(1:message_length_max+2),border_pixel),[bi_message_length  de2bi(mode,2)]);
    half=0;
    [mod_P(:,:,mode) ec1]=skewed_histogram_shifting(re_P,half,mode,message(1:round(end/2)));
    half=1;
    [mod_P(:,:,mode) ec2]=skewed_histogram_shifting(mod_P(:,:,mode),half,mode,message(ec1+1:end));
    toc
    if ec1+ec2 == total_message_length
        disp([num2str(message_length) ' bits embedded!'])
        disp(['PSNR is ' num2str(psnr(original_image,mod_P(:,:,mode),255))])
        result(mode)=psnr(original_image,mod_P(:,:,mode),255);
    else
        disp('failed')
    end
end

%Find predictor which gives maxmimum psnr
[max_result,max_index]=max(result);
if max_result ~= 0
    watermarked_image=mod_P(:,:,max_index);
else
    disp('failed')
end

%Decoding
[re_original, re_message]=main_decode(watermarked_image);

%check if extracted messages are correct and pixels are recovered 
isequal(re_original,original_image)
isequal(re_message,original_message)
2