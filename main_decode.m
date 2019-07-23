function [re_original, re_message]=main_decode(watermarked_image)

[re_mod_P2, re_message2]=decode_skewed_histogram_shifting(watermarked_image,1);
[re_mod_P1, re_message1]=decode_skewed_histogram_shifting(re_mod_P2,0);
re_message=[re_message1 re_message2];

%Undo preprocessing
[re_n re_m]=size(watermarked_image);
re_message_length_max=floor(log2(re_n*re_m));
re_length_loc_map_max=ceil(log2((re_n-2)*(re_m-2)));

%side information
re_border_pixel=re_message(1:re_message_length_max+2);

start_pos=re_message_length_max+2+1;
re_location_map_length=bi2de(re_message(start_pos:start_pos+re_length_loc_map_max-1));

start_pos=start_pos+re_length_loc_map_max;
re_location_map=re_message(start_pos:start_pos+re_location_map_length-1);
re_message(1:start_pos+re_location_map_length-1)=[];
%Recover border pixel
re_mod_P1(1:re_message_length_max+2)=bitxor(bitxor(re_mod_P1(1:re_message_length_max+2),mod(re_mod_P1(1:re_message_length_max+2),2)),re_border_pixel);
if isempty(re_location_map)
    re_original=re_mod_P1;
else
    [re_original]=re_preproces_image(re_mod_P1,re_location_map);
end
