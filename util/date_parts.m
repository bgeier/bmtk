function [month,day,year] = date_parts(dates)
num_dates = length(dates);

month = cell(num_dates,1); 
day = cell(num_dates,1); 
year = cell(num_dates,1); 
for i =1 : num_dates
    str = dates{i};
    ix = find(str=='/'); 
    month{i} = str(1:ix(1)-1); 
    day{i} = str(ix(1)+1:ix(2)-1); 
    year{i} = str(ix(2)+1:end); 
end
