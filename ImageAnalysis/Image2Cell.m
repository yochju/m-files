function out = Image2Cell(in)

ImSize = size(in);
ImLayout = arrayfun(@(x) ones(1,x), ImSize(1:2), 'UniformOutput', false);

for i = 3:length(ImSize)
    ImLayout{i} = ImSize(i);
end

out = cellfun(@(x) squeeze(x), ...
    mat2cell(in, ImLayout{:}), ...
    'UniformOutput', false);

end
