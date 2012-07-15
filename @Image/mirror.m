function out = mirror(obj,size)
l_data = double(obj(:,1:size));
t_data = double(obj(1:size,:));
r_data = double(obj(:,(end-size+1):end));
b_data = double(obj((end-size+1):end,:));
out = obj.pad('left',l_data,'right',r_data,'top',t_data,'bottom',b_data);
out.padding = size*ones(1,4);
end