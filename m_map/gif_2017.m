%% ===============================================================
%  西北太平洋 SSHg 2007 vs 2017 年季节与年代对比分析
%  仅做 SSHg 场分布与区域平均时间序列对比（不含地转流）
% ===============================================================
clear; clc; close all;

basePath = '/Users/macbookair15/Desktop/海洋气象学/m_map/';
outdir   = '/Users/macbookair15/Desktop/SSH/';
if ~exist(outdir,'dir'); mkdir(outdir); end

REG_LON = [120 160];
REG_LAT = [10 40];
years   = [2007 2017];

cmap = turbo(256);
deg2rad = pi/180;
Re = 6371000;
region_title = sprintf('(%g°–%g°E, %g°–%g°N)',REG_LON(1),REG_LON(2),REG_LAT(1),REG_LAT(2));

% 结果结构体
data = struct();

for y = years
    fname = fullfile(basePath, sprintf('sshg.%d.nc',y));
    if ~isfile(fname)
        warning('文件不存在: %s', fname); continue;
    end

    lon  = double(ncread(fname,'lon'));
    lat  = double(ncread(fname,'lat'));
    time = double(ncread(fname,'time'));
    sshg = double(ncread(fname,'sshg'));

    if size(sshg,1)==numel(lon)
        sshg = permute(sshg,[2 1 3]); % (lat,lon,time)
    end

    refDate = datetime(1800,1,1,0,0,0);
    t_dt = refDate + days(time);
    mo = month(t_dt);

    lon_idx = lon>=REG_LON(1) & lon<=REG_LON(2);
    lat_idx = lat>=REG_LAT(1) & lat<=REG_LAT(2);
    lon_sub = lon(lon_idx);
    lat_sub = lat(lat_idx);
    SSH = sshg(lat_idx,lon_idx,:);

    % === 四季平均 ===
    DJF = mean(SSH(:,:,ismember(mo,[12 1 2])),3,'omitnan');
    MAM = mean(SSH(:,:,ismember(mo,[3 4 5])),3,'omitnan');
    JJA = mean(SSH(:,:,ismember(mo,[6 7 8])),3,'omitnan');
    SON = mean(SSH(:,:,ismember(mo,[9 10 11])),3,'omitnan');
    YEAR = mean(SSH,3,'omitnan');

    % 区域平均时间序列
    ssh_mean = squeeze(mean(SSH,[1 2],'omitnan'));

    data.(sprintf('Y%d',y)).lon = lon_sub;
    data.(sprintf('Y%d',y)).lat = lat_sub;
    data.(sprintf('Y%d',y)).time = t_dt;
    data.(sprintf('Y%d',y)).SSH = SSH;
    data.(sprintf('Y%d',y)).meanTS = ssh_mean;
    data.(sprintf('Y%d',y)).DJF = DJF;
    data.(sprintf('Y%d',y)).MAM = MAM;
    data.(sprintf('Y%d',y)).JJA = JJA;
    data.(sprintf('Y%d',y)).SON = SON;
    data.(sprintf('Y%d',y)).YEAR = YEAR;
end

%% === 统一色标（基于所有数据） ===
clim = [min(data.Y2007.YEAR,[],'all') max(data.Y2017.YEAR,[],'all')];

%% === (1) 四季对比：2007 vs 2017 ===
seasons = {'DJF','MAM','JJA','SON'};
titles  = {'冬季','春季','夏季','秋季'};
for i = 1:4
    figure('Position',[100 100 1100 520]);
    sname = seasons{i};

    % 左：2007
    subplot(1,2,1);
    m_proj('mercator','lon',REG_LON,'lat',REG_LAT);
    m_contourf(data.Y2007.lon,data.Y2007.lat,data.Y2007.(sname),24,'LineColor','none');
    caxis(clim); colormap(cmap); colorbar;
    m_coast('color','k'); m_grid('box','fancy','tickdir','in');
    title(sprintf('%s 2007年 %s SSHg %s',titles{i},titles{i},region_title));

    % 右：2017
    subplot(1,2,2);
    m_proj('mercator','lon',REG_LON,'lat',REG_LAT);
    m_contourf(data.Y2017.lon,data.Y2017.lat,data.Y2017.(sname),24,'LineColor','none');
    caxis(clim); colormap(cmap); colorbar;
    m_coast('color','k'); m_grid('box','fancy','tickdir','in');
    title(sprintf('%s 2017年 %s SSHg %s',titles{i},titles{i},region_title));

    sgtitle(sprintf('%s季节 SSHg 对比 (2007 vs 2017)',titles{i}));
    set(gcf,'Color','w');
    saveas(gcf, fullfile(outdir, sprintf('SSHg_%s_2007vs2017.png',sname)));
    print(gcf, fullfile(outdir, sprintf('SSHg_%s_2007vs2017',sname)), '-dpdf','-r300');
end

%% === (2) 年平均对比 ===
figure('Position',[100 100 1000 480]);
subplot(1,2,1);
m_proj('mercator','lon',REG_LON,'lat',REG_LAT);
m_contourf(data.Y2007.lon,data.Y2007.lat,data.Y2007.YEAR,24,'LineColor','none');
caxis(clim); colormap(cmap); colorbar;
m_coast('color','k'); m_grid('box','fancy','tickdir','in');
title(sprintf('2007年 年平均 SSHg %s',region_title));

subplot(1,2,2);
m_proj('mercator','lon',REG_LON,'lat',REG_LAT);
m_contourf(data.Y2017.lon,data.Y2017.lat,data.Y2017.YEAR,24,'LineColor','none');
caxis(clim); colormap(cmap); colorbar;
m_coast('color','k'); m_grid('box','fancy','tickdir','in');
title(sprintf('2017年 年平均 SSHg %s',region_title));

sgtitle('2007 与 2017 年年平均 SSHg 对比');
set(gcf,'Color','w');
saveas(gcf, fullfile(outdir,'SSHg_Annual_2007vs2017.png'));
print(gcf, fullfile(outdir,'SSHg_Annual_2007vs2017'),'-dpdf','-r300');

%% === (3) 区域平均时间序列（2007 vs 2017） ===
fprintf('\n=== 生成 2007 vs 2017 区域平均时间序列 ===\n');

% 提取每年各月平均（1~12 月）
months = 1:12;
mean2007 = NaN(1,12);
mean2017 = NaN(1,12);

for m = 1:12
    idx07 = month(data.Y2007.time) == m;
    idx17 = month(data.Y2017.time) == m;
    mean2007(m) = mean(data.Y2007.meanTS(idx07), 'omitnan');
    mean2017(m) = mean(data.Y2017.meanTS(idx17), 'omitnan');
end

% === 绘图 ===
figure('Position',[150 150 900 400]);
hold on; grid on; box on;

plot(months, mean2007, '-o', 'LineWidth', 2.0, ...
    'Color', [0.85 0.2 0.2], 'MarkerFaceColor', [0.9 0.3 0.3]); % 红线
plot(months, mean2017, '-s', 'LineWidth', 2.0, ...
    'Color', [0.2 0.4 0.8], 'MarkerFaceColor', [0.3 0.5 0.9]); % 蓝线

xlim([1 12]);
xticks(1:12);
xlabel('月份 (Month)');
ylabel('区域平均 SSHg（原始单位）');
legend('2007 年','2017 年','Location','best');
title(sprintf('区域平均 SSHg 月变化对比 %s', region_title));
set(gca,'FontSize',12);
set(gcf,'Color','w');

% 保存输出
saveas(gcf, fullfile(outdir, 'SSHg_RegionalMean_TS_2007vs2017.png'));
print(gcf, fullfile(outdir, 'SSHg_RegionalMean_TS_2007vs2017'), '-dpdf', '-r300');
fprintf('✅ 已保存：%s\n', fullfile(outdir, 'SSHg_RegionalMean_TS_2007vs2017.png'));