function S_hat = ID_FSD(R)
    global C;
    radius = 1.5;  % 设置初始球形半径
    [N, M] = size(R);  % 获取R的维度，N为子载波数量，M为符号数量
    
    S_hat = zeros(N, M);  % 初始化解码符号矩阵
    
    % QR分解
    [Q, R_qr] = qr(C); 

    for m = 1:M
        R_tilde = Q' * R(:, m);  % 对每个符号进行处理
        S_hat(:, m) = simple_sd(R_qr, R_tilde, radius, N);  % 执行简化球形解码
    end
end

function S_est = simple_sd(R_qr, R_tilde, radius, N)
    s_n = [1 + 1i, 1 - 1i, -1 + 1i, -1 - 1i];  % QPSK符号集
    S_est = zeros(N, 1);  % 初始化符号估计
    min_metric = inf;  % 初始化最小度量为无穷大

    for symbol = s_n
        % 从最后一个符号开始，尝试所有符号可能性
        for n = N:-1:1
            S_est(n) = symbol;
            metric = norm(R_tilde - R_qr * S_est)^2;  % 计算误差度量
            
            if metric < min_metric
                min_metric = metric;  % 更新最小度量
                best_S = S_est;  % 保存当前最好的符号估计
            end
        end
    end
    S_est = best_S;  % 返回最优符号估计
end
