function [m_image loc_map location_map_length]=preproces_image(image)
m_image=image;
[n m]=size(m_image);
counter=0;
location_map_temp=zeros(1,n*m);
for i1=2:n-1
    for j1=2:m-1
        if m_image(i1,j1)==0 || m_image(i1,j1)==255
            counter=counter+1;
            if m_image(i1,j1)==0
                m_image(i1,j1)=1;
            else
                m_image(i1,j1)=254;
            end
            location_map_temp(counter)=1;
        elseif m_image(i1,j1)==254 || m_image(i1,j1)==1
            counter=counter+1;
            location_map_temp(counter)=0;
        end
    end
end
% counter
location_map=location_map_temp(1:counter);
length_loc_map_max=ceil(log2((n-2)*(m-2)));
if  isempty(location_map)
    loc_map=[];
    location_map_length=de2bi(0,length_loc_map_max);
    length_vector1=char(zeros(1,length_loc_map_max)+48);
else
    xE=cell(1,1);
    xE{1}=[location_map];
    
    y4=arith07(xE);
    
    loc_map=reshape(de2bi(y4,8),1,[]);
    location_map_length=de2bi(length(loc_map),length_loc_map_max);
end