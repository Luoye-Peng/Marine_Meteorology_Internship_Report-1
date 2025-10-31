%% ==========================================================
%  SSHg 原始数据读取与可视化（不做比例因子转换）
%  文件：sshg.2017.nc
%  绘制：月平均、年平均、12个月空间平均时间序列
% ===========================================================

clear; clc; close all;

fname = '/Users/macbookair15/Desktop/海洋气象学/m_map/sshg.2007.nc';

%% === 1. 查看文件信息 ===
info = ncinfo(fname);
disp('📦 文件包含的变量：');
disp({info.Variables.Name}');

%% === 2. 读取基础变量 ===
lon  = ncread(fname, 'lon');
lat  = ncread(fname, 'lat');
time = ncread(fname, 'time');
sshg = ncread(fname, 'sshg');    % 原始 int16 数据

% 检查维度顺序
if size(sshg,1) == length(lon)
    sshg = permute(sshg, [2 1 3]);  % 调整为 (lat, lon, time)
end

[nlat, nlon, ntime] = size(sshg);
fprintf('✅ SSHg 数据维度: %d×%d×%d (lat×lon×time)\n', nlat, nlon, ntime);

%% === 3. 计算统计量（原始值） ===
minSSH = min(sshg(:));
maxSSH = max(sshg(:));
meanSSH = mean(double(sshg(:)),'omitnan');

fprintf('📊 原始SSHg范围: %d ~ %d (平均值 = %.2f)\n', minSSH, maxSSH, meanSSH);

%% === 4. 时间变量转日期 ===
refDate = datetime(1800,1,1,0,0,0);
time_dt = refDate + days(time);
disp('🕓 时间序列:');
disp(time_dt);

%% === 5. 设置显示参数 ===
lonlim = [-180 180];
latlim = [-80 80];
clim = [double(minSSH) double(maxSSH)];  % 自动使用原始范围
cmap = parula(200);

%% === 6. 绘制 12个月 平均图（原始数据） ===
figure('Position',[100 100 1200 800]);
tiledlayout(3,4,'Padding','compact','TileSpacing','compact');

for k = 1:ntime
    nexttile;
    m_proj('robinson','lon',lonlim,'lat',latlim);
    m_pcolor(lon, lat, double(sshg(:,:,k))); shading interp;
    m_coast('color','k');
    m_grid('box','fancy','tickdir','in');
    title(datestr(time_dt(k),'yyyy年mm月'));
    caxis(clim);
    colormap(cmap);
end

cb = colorbar('Position',[0.92 0.25 0.015 0.5]);
cb.Label.String = 'SSHg (原始单位)';
sgtitle('2007年 月平均 SSHg 原始数据分布');

%% === 7. 年平均图 ===
sshg_year = mean(double(sshg),3,'omitnan');

figure('Position',[200 200 900 450]);
m_proj('robinson','lon',lonlim,'lat',latlim);
m_pcolor(lon, lat, sshg_year); shading interp;
m_coast('color','k'); m_grid('box','fancy','tickdir','in');
colorbar; colormap(cmap);
caxis(clim);
title('2007年 年平均 SSHg (原始值)');

%% === 8. 12个月空间平均时间序列（原始数据） ===
sshg_mean_time = squeeze(mean(double(sshg),[1 2],'omitnan'));

figure('Position',[200 200 700 350]);
plot(time_dt, sshg_mean_time, '-o', 'LineWidth',1.5, 'Color',[0.2 0.5 0.8]);
xlabel('时间'); ylabel('SSHg (原始单位)');
title('2007年 SSHg 空间平均时间序列 (原始值)');
grid on;