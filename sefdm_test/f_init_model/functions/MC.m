function [S_est] = MC(R)
    % Monte Carlo Detection for AWGN channel
    % R - 包含统计数据的矩阵，每列对应一个单独的 SEFDM 字符

    global random_signals;
    global monte_carlo_samples;
    global C;

    N = size(R, 1); % 获取子载波的数量
    W = size(R, 2); % 获取每个符号的长度

    S_est = zeros(N, W);

    for k = 1:W
        % 初始化最小误差
        min_error = inf;
        best_signal = zeros(N, 1);

        for s = 1:monte_carlo_samples
            % 计算当前样本信号的误差
            current_signal = random_signals(:, s);
            error = norm(R(:, k) - C * current_signal, 'fro')^2;

            % 如果当前误差比最小误差更小，更新最优解
            if error < min_error
                min_error = error;
                best_signal = current_signal;
            end
        end

        % 将最优解赋给估计的符号
        S_est(:, k) = best_signal;
    end
end
