for i = 1:402

    mean_supply(i) = mean(supply_data(i, :));         
    
    valid_weeks = find(order_data(i, :) > 0);        
    if ~isempty(valid_weeks)
        ratio = supply_data(i, valid_weeks) ./ order_data(i, valid_weeks);
        reliability(i) = sum(ratio >= 0.9) / numel(valid_weeks); 
        cv = std(ratio) / mean(ratio);                
        stability(i) = 1 / (cv + eps);               
    else
        reliability(i) = 0;  
        stability(i) = 0;     
    end
    
    switch order_table.VarName2(i)
        case 'A', material_weight(i) = 1.2;  
        case 'B', material_weight(i) = 1.1;  
        case 'C', material_weight(i) = 1.0;  
    end
end

X = [mean_supply; stability; reliability; material_weight]';

X_norm = normalize(X, 'range');  

p = X_norm ./ sum(X_norm, 1);     
e = -sum(p .* log(p + eps), 1);    
w = (1 - e) / sum(1 - e);           


score = X_norm * w';             

[~, idx] = sort(score, 'descend');

top50_suppliers = table(...
    order_table.ID(idx(1:50)), ...
    order_table.VarName2(idx(1:50)), ...
    score(idx(1:50)), ...
    (1:50)', ...
    'VariableNames', {'SupplierID', 'MaterialType', 'Score', 'Rank'});

writetable(top50_suppliers, 'Top50_Suppliers.xlsx');

figure;
scatter(1:402, score, 25, 'b', 'filled');
hold on;

scatter(idx(1:50), score(idx(1:50)), 40, 'r', 'filled');

xlabel('供应商编号');
ylabel('综合得分');
title('供应商重要性得分分布（红色为Top 50）');
legend('其他供应商', 'Top 50');
grid on;