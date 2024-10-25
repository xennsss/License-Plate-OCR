close all
a = dir('I:\vc\VC SP QT 2022\day_color(small sample)\*.jpg');
nf = size(a);
%per ara nomes utilitzare car 1,2 i 3
%for i = 1:10
    %filename = horzcat(a(i).folder,'/',a(i).name);
    %I = rgb2gray(imread(filename));
I = imread('car3.jpg');

%%preprocess
figure,imshow(I)
Ig = rgb2gray(I);
figure,imshow(Ig)
Im = medfilt2(Ig); %realiza un filtrado de mediana de la imagen I en dos dimensiones (quitar salt and pepper)
figure,imshow(Im)
Ibw = thresholdLocally(Im, 50);
figure,imshow(Ibw)
Imovavg = moving_averages(Im,20);
figure,imshow(Imovavg)
k3 = strel('square', 3);
Io = imopen(Ibw, k3);
figure,imshow(Io)
Ic = imclose(Io, k3);
figure,imshow(Ic)

%%buscar matricules
matricula = placa(Ic)




%treure = placa(bin);
%solsplaca = markers(treure);
%impixelinfo
%drawnow
%pause
%end


function img = placa(im)
    [L, n] = bwlabel(im); %etiqueta los componentes concectados y n es el numero de obj conectados 
    Iwidth = size(im, 2);
    Iheight = size(im, 1);
    P = regionprops(L, 'BoundingBox', 'EulerNumber'); %devuelve las mediciones del conjunto de propiedades de cada componente 
    % EulerNumber = Número de objetos en la región menos el número de huecos en esos objetos, devuelto como un escalar
    euler = cat(1, P.EulerNumber);
    boundingBox = cat(1, P.BoundingBox);
    height = boundingBox(:,4);
    width = boundingBox(:,3);
    img = boundingBox( euler <= -1 & euler >= -25 & width > 2*height & width < 0.8*Iwidth & height > 0.05*Iheight,:);
    
end

   
function imbw = thresholdLocally(Im, step)
f = size(Im,1);
c = size(Im,2);
mat = zeros(f,c, 'double');

for i = 1:step:f
  for j = 1:step:c
    iend = i + step;
    if(iend > f) 
        iend = f; 
    end
    jend = j + step;
    if(jend > c) 
        jend = c; 
    end
    thresh = graythresh(Im(i:iend,j:jend));
    mat(i:iend,j:jend) =  thresh;
  end
end

k = fspecial('average', step);
mat = imfilter(mat, k);

imbw = im2double(Im);
imbw(imbw < mat) = 0;
imbw(imbw >= mat) = 1;

end


function imbw  = moving_averages(im, n)
 h = ones(n)/n^2; % promig
 promig = imfilter(double(im), h, 'conv', 'replicate');
 %figure, imshow(promig), title('imatge promig');
 imbw = im > promig;
end



function img = markers(im)
    mark = im;
    mark(2:end-1,2:end-1) = 0;
    rec = imreconstruct(mark, im);
    img = imsubtract(im, rec);
end