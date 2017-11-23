function map = makeColorMap(color, bits)
global gh state

if nargin < 1
    color='gray';
    bits=8;
elseif nargin < 2
    bits=8;
end
a = zeros(2^bits,1);
b = (0:1/(2^bits -1):1)';

if isfield(state,'internal')
    if isfield(state.internal,'colormapSaturationFraction');
        fraction=state.internal.colormapSaturationFraction;
    end
else
    fraction=.05;
end
index=round(fraction*length(b));
switch color 
case 'red'
	map = squeeze(cat(3, b, a, a));
case 'green'
	map = squeeze(cat(3, a, b, a));
case 'blue'
	map = squeeze(cat(3, a, a, b));
case 'gray'
	map = squeeze(cat(3, b, b, b));
case 'grayPlusSat'
	map = squeeze(cat(3, b, b, b));
    map(end-index:end,[2 3])=0;
case 'grayMinusSat'
	map = squeeze(cat(3, b, b, b));
    map(1:index,[1 3])=0;
    map(1:index,2)=flipud(linspace(.8,1,length(map(1:index,2)))');
case 'grayPlusMinusSat'
	map = squeeze(cat(3, b, b, b));
    map(end-index:end,[2 3])=0;
    map(1:index,[1 3])=0;
    map(1:index,2)=flipud(linspace(.8,1,length(map(1:index,2)))');
end

	