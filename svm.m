%%by WTTAT
clc;
clear;

%加载报文数据
%S = import('can.txt');
load canid_data.mat
Fre = tabulate(CANID);% 计算出现的频率
Seq = sortrows(Fre,-size(Fre,2)); % 根据频率降序排列

% figure
% plot(S2(:,1),S2(:,2));

% 挑选800个CANID为 0*40 的报文,并把对应的DATA提取出来
Data_temp = cell(800,1);
ii=1;
for i=1:57970
    if strcmp(CANID(i),'44')
        Data_temp(ii,1) = DATA(i);
        ii=ii+1;
    end;
    if ii==801
                break;
    end
end

% 字符串按空格拆分
Data = cell(800,8);
for n=1:800
    Data_temp(n,1) = deblank(Data_temp(n,1));
    Data(n) = regexp(Data_temp(n,1), '\s', 'split');
%     S4(n) = strsplit(S3(n),','); %failed
    Data(n,:)= Data{n,1};
end
    
% 转换成十进制
train_temp = zeros(800,8);
for x=1:800
    for y=1:8
        train_temp(x,y)=hex2dec(Data(x,y));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 生成训练集和测试集
% 样本集标签 前200位为1，后200位为-1
% 训练集标签 前200位为1，后200位为-1
train_label = ones(400,1);
test_label = ones(400,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Strain为训练集
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for x1 = 1:200
    for y1=1:8
    train(x1,y1) = train_temp(x1,y1);
    end
    train_label(x1) = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for x1 = 201:400
    for y1=1:8
    train(x1,y1) = train_temp(x1,y1);
    end
    train_label(x1) = -1;
    
%%%%%%%%%%%%%%%%%%
%  用这一段是有两位是随机
%%%%%%%%%%%%%%%%%%  
%     z = randi(7);
%     train(x1,z) = randi(256)-1;
%     train(x1,z+1) = randi(256)-1;
%%%%%%%%%%%%%%%%%%
%  用这一段是随机两位或者三位随机
%%%%%%%%%%%%%%%%%% 
    z = randi(6);
    zz = randi(2);
    if zz == 1
    train(x1,z) = randi(256)-1;
    train(x1,z+1) = randi(256)-1;
    else
    train(x1,z) = randi(256)-1;
    train(x1,z+1) = randi(256)-1;
    train(x1,z+2) = randi(256)-1;
    end
%%%%%%%%%%%%%%%%%%
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stest 为测试集
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for x1 = 401:600
    for y1=1:8
    test(x1-400,y1) = train_temp(x1-400,y1);
    end
    test_label(x1-400) = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for x1 = 601:800
    for y1=1:8
    test(x1-400,y1) = train_temp(x1-400,y1);
    end
    test_label(x1-400) = -1;
%%%%%%%%%%%%%%%%%%
%  用这一段是有两位是随机
%%%%%%%%%%%%%%%%%%  
%     z = randi(7);
%     test(x1-400,z) = randi(256)-1;
%     test(x1-400,z+1) = randi(256)-1;
%%%%%%%%%%%%%%%%%%
%  用这一段是随机两位或者三位随机
%%%%%%%%%%%%%%%%%%    
    z = randi(6);
    zz = randi(2);
    if zz == 1
    test(x1-400,z) = randi(256)-1;
    test(x1-400,z+1) = randi(256)-1;
    else
    test(x1-400,z) = randi(256)-1;
    test(x1-400,z+1) = randi(256)-1;
    test(x1-400,z+2) = randi(256)-1;
    end
%%%%%%%%%%%%%%%%%%

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

model= svmtrain(train_label, train, '-t 1 -c 1 -g 1 -b 1');

[predict_label,accuracy,decision_values]=svmpredict(test_label,test,model);
