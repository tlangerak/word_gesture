function out = estimation(trackdata,layout,letters_and_numbers, dictionary)

%Make sure to remove this if block so you can test your function
% if 1
%     out = 'Not implemented yet';
%     return
% end

%%This section maps each point in the trackdata vector to a layout
%Nothing to implement here
n = size(trackdata,1);
letter_outcome = zeros(n,1);
fullstring = char(letter_outcome)';
currentrow = zeros(n,1);

for i = 1: length(trackdata)
    xpos = trackdata(i,1);
    ypos = trackdata(i,2);
    for j = 1: length(layout)
        if xpos >= layout(j,1) && xpos <= layout(j,3) && ypos <= layout(j,2) && ypos >= layout(j,4) 
            letter_outcome(i) = letters_and_numbers{j,2};
            fullstring(i) = char(letter_outcome(i));
         end
    end
    if ypos >=103 && ypos <=204
        current_row(i) = 1;
    elseif ypos >=205 && ypos <= 306
        current_row(i) = 2;
    elseif ypos >=307 && ypos <= 409
        current_row(i) = 3;
    else
        current_row(i) = 0;
    end
end
current_row(find(current_row==0)) = [];
%END BLOCK

fullstringDif=diff(fullstring); %find the differences between consecutive letters. 

n=1;
for i=1:length(fullstringDif) %only keep one letter if there are multiple similar after eachother
  if fullstringDif(i) ~= 0
      fullstringNew(n)=fullstring(i);
      n=n+1;
  end
end
fullstringNew(n)=fullstring(end); %for some reason the last letter always dropped out in the loop above. 
fullstring=fullstringNew %update fullstring

%Remove bad characters
fullstring = fullstring(fullstring>0);

%STEP 2: find the words in the dictionary with the same first and last letter as fullstring
%Store this in a cell array called filtered_words

file='dictionary.csv'; %load the dictionary and save it in a cell. 
fid = fopen(file,'r');
C = textscan(fid, '%s', 'delimiter',',', 'CollectOutput',true);
C = C{1};
fclose(fid);

nWords=1;
nChance=1;

for t=1:length(C) %sort the dictionary in a cell array for words and a cell array for occurence. 
    if mod(t,2) == 1
        words(nWords)=C(t,1);
        nWords=nWords+1;
    else
        chance(nChance)=C(t,1);
        nChance=nChance+1;
    end
end

count=1;

for y=1:length(words)
   wordCheck=char(words(y));
     if fullstring(1)==wordCheck(1) && fullstring(end)==wordCheck(end) %checl whether the first and last letter match for every word in the dictionary. 
       filtered_words_chance(count)=chance(y);
       filtered_words(count)=words(y);
       count=count+1;
     end
end

%STEP 3: compute an association score between fullstring and each of the 
%candidate words in filtered_words.
%For example, you could count the number of matching characters and
%normalise by the length of the string.

for u=1:length(filtered_words) %check the amount of similar characters in the full string.
    matchCounter=0; 
    charCheck=char(filtered_words(u));
    for e=1:length(fullstring) %I should be able to do something here with also character sequence, however this was not within my time frame
        for q=1:length(charCheck)
         if fullstring(e)==charCheck(q)
             matchCounter=matchCounter+1;
         end
        end    
    end
    similar_character_score(u)=matchCounter/length(charCheck); %I would have thought that I will to correct with length(fullstring), but this gives better results. 
end

for p=1:length(filtered_words)
    fwc=str2num(cell2mat(filtered_words_chance(p)));
    scs=similar_character_score(p);
    association_score(p)=fwc.*scs; %I am calculating the association score by multiplying the occurence of the word in the English language and the similar character score 
end

%%STEP 4: Count the number of row transitions in the data (call it r). 
%Delete any words from filtered_words which have length < r - 2.
%A row transition occurs whenever the value of currentrow at position i
%is different than it was at position i-1

row1={'q', 'w', 'e', 'r', 't','y','u','i','o','p'};
row2={'a','s','d','f','g','h','j','k','l'};
row3={'z','x','c','v','b','n','m'};

row=0;
rowCount=0;

for j=1:length(fullstring) %checking the amount of row transistions in the original data. 
  if ismember(fullstring(j), row1) && row ~=1
      rowCount=rowCount+1;
      row=1;    
  elseif ismember(fullstring(j), row2) && row ~=2
      rowCount=rowCount+1;
      row=2;    
  elseif ismember(fullstring(j), row3) && row~=3
      rowCount=rowCount+1;
      row=3;
  end
end

rowCount=rowCount-1 %correct for the fact that the start is counted as a row transistion. 

for k=1:length(filtered_words)
  rowCheck=char(filtered_words(k));
  if length(rowCheck) < rowCount-2
      disp(rowCheck)
      filtered_words(k)={''}; %empty the cell
  end
end

for n=1:length(filtered_words)
  rowCheck=char(filtered_words(n));
  if length(fullstring) < length(rowCheck) %assuming that the user touches all letters in the word, any words which are longer than the orginal data input can be delete (this is rare)
      filtered_words(n)={''};
  end
end

count = 0;

for b=1:length(filtered_words)
    deleteCheck=char(filtered_words(b));
    if ~isempty(deleteCheck) %when a cell is not empty store the contents of that cell in a new array. 
        count=count+1;
        filtered_words_new(count)=filtered_words(b);
        association_score_new(count)=association_score(b);
    end
end


%%STEP 5: Sort filtered_words in decreasing order of association score
[~, I]=sort(association_score_new, 'descend'); %I gives the index order of the sorting, this is needed to sort the words
for q=1:length(I)
    new_filtered_words(I(q))=filtered_words_new(q); %switch the filered_words to their new places determind by I    
end

filtered_words=new_filtered_words;

if length(filtered_words) < 3 %since there are occassions in which filtered_words < 3 (for instance when the swipe was 'a'), some error handling. 
    disp(filtered_words(1:length(filtered_words)))
    out = filtered_words(1:length(filtered_words));
else
    disp(filtered_words(1:3))
    out = filtered_words(1:3);
end





