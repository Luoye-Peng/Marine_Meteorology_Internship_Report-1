clc;clear;
file1 = 'sshg.2007.nc';
file2 = 'sshg.2017.nc';

info1 = ncinfo(file1)
info2 = ncinfo(file2)

{info1.Variables.Name}'
info = ncinfo('/Users/macbookair15/Desktop/海洋气象学/m_map/sshg.2017.nc');
idx = find(strcmp({info.Variables.Name}, 'sshg'));
info.Variables(idx)


{info1.Attributes.Name}'
