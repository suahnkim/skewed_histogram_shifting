function main
rng(0)
original_image=double(rgb2gray(imread('4.2.03.tiff')));
message_length=5000;
original_message=randi([0,1],1,message_length);
watermarked_image = main_encode(original_image,original_message);

if isempty(watermarked_image)
    disp('failed to embed')
else
    disp(['Best psnr for the payload is ' num2str(psnr(original_image, watermarked_image,255))])
end

%Decoding check
[re_original, re_message]=main_decode(watermarked_image);

%check if extracted messages are correct and pixels are recovered
if isequal(re_original,original_image)
    disp('Recovered the original image')
else
    disp('Failed to recover the original image')
end

if isequal(re_message,original_message)
    disp('Recovered the payload')
else
    disp('Failed to recover the payload')
end