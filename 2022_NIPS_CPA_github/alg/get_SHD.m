function[Score]= get_SHD(struC,skeleton)
a = sum(sum(struC.*skeleton));
b = sum(sum(struC));
c = sum(sum(skeleton));
Score = (b-a)+(c-a);
end