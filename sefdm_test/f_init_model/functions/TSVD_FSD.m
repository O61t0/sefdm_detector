function [S_FSD_TSVD] = TSVD_FSD(R)
    % FSD-TSVD Detection for AWGN channel
    % R - 包含统计数据的矩阵，每列对应一个单独的 SEFDM 字符

    global trunc_C;

    % Step 1: TSVD Estimation
    P_hat = trunc_C * R;  % 使用TSVD估计

    % Step 2: Compute Initial Radius
    % 计算初始搜索半径
    g_hat = norm(R - P_hat, 'fro')^2;

    % Step 3: FSD Detection
    % 执行FSD检测算法
    S_FSD_TSVD = FSD(P_hat, R, g_hat);

end

function [S_final] = FSD(P_hat, R, g_hat)
    % FSD detection algorithm for AWGN channel
    % R 为接收的信号矩阵
    % P_hat 为TSVD估计的信号矩阵
    % g_hat 为计算的搜索半径

    N = size(R, 1); % 获取子载波的数量
    W = size(R, 2); % 获取每个符号的长度

    % 初始化FSD
    S_final = P_hat;
    AED_min = norm(R - P_hat, 'fro')^2;

    % 搜索更优解
    for m = N:-1:1
        d = 0; % 初始化d
        for n = N:-1:m
            % 避免超出数组边界的问题
            if n <= size(S_final, 1) && n <= size(P_hat, 1)
                d = norm(S_final(n, :) - P_hat(n, :), 'fro') + d;
            end
        end
        % 确保d是一个标量，并进行排序
        if numel(d) > 1
            d = sort(d);
        end
    end

    % 如果找到更小的距离，更新最终结果
    if AED_min < g_hat
        S_final = P_hat;
    end
end
