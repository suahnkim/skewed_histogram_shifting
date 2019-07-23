function [preprocess_image]=re_preproces_image(preprocess_image,location_map)
[n m]=size(preprocess_image);


xC = arith07(bi2de(reshape(location_map,[],8)));

re_location_map=xC{1};
counter=1;

for i1=2:n-1
    for j1=2:m-1
        if counter < length(re_location_map)
            if preprocess_image(i1,j1)==1 || preprocess_image(i1,j1)==254
                if re_location_map(counter)==1
                    if preprocess_image(i1,j1)==1
                        preprocess_image(i1,j1)=0;
                    else
                        preprocess_image(i1,j1)=255;
                    end
                    counter=counter+1;
                end
            end
        end
    end
end
% counter