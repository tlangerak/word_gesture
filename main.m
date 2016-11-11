clear all; close all;
load layout;
keyboard = imread('keyboard2.png');
dictionary = read_dictionary2('dictionary.csv');

qwertystring = ('qwertyuiopasdfghjklzxcvbnm');
for i = 1: 26
    letters_and_numbers{i,1} = i;
    letters_and_numbers{i,2} = qwertystring(i);
end

%mylayout = CenterPoint(layout);
uiwait(msgbox('start with first click and stop with second click'));

trackdata = mousetrack(keyboard);

hold on
plot(trackdata(:,1),trackdata(:,2),'r','Linewidth',4)

out = estimation(trackdata,layout,letters_and_numbers,dictionary)
