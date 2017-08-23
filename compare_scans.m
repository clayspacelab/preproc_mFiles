function fh = compare_scans(niis,fout,vols,coords,clims)
% compare_scans Generate gif of several (2 or more) scans
%   compare_scans(myniis) generates a gif to myscans.gif looping through
%   each nii in myniis. If myniis is a cell array of strings, loads each
%   nii file using niftiRead (requires vistasoft). If any of mynii is more
%   than a single volume, uses the first volume. Defaults to middle slice
%   in axial, sagital, coronal. myniis must have 2 or more entries when
%   only argument.
%
% compare_scans(myniis,fout) saves gif to fout. If no extension, .gif is
% added.
%
% compare_scans(myniis,fout,vols) indexes into each nii in myniis using
% vols. If myniis contains only one image/string, vols must contain 2 or
% more elements. vols can contain a single value if more than one nii
% provided (same volume used for each nii). otherwise, must match size of
% myniis (matching index applied to mynii)
%
% compare_scans(mynii,fout,vols,coords) slices according to coords. See
% niftiPlotSlices.m for how coords is used.
%
% compare_scans(mynii,fout,vols,coords,clims) specifies color limits for
% images. If single pair provided, same values used across all volumes.
% Otherwise, must be n_vols pairs of color limits, which correspond to each
% nii/volume
%
% fhan = compare_scans(...) returns the figure handles to all figures
% returned by niftiPlotSlices
%
% niftiPlotSlices (helper function) will reorient images to RAI, so not
% necessary to ensure images match. coords, clims must have number of rows
% either matching number of images or a single row. 
%



% Updated 8/14/2017 - allows multiple colormap inputs, as well as option
% 'each' to use range of each image (presently, full volume)

% Tommy Sprague (tommy.sprague@gmail.com); NYU


% check if niis is valid - must be cell of str, str, nifti struct, or cell
% of nifti structs

% if niis is a string, make it a cell array
if ischar(niis)
    niis = {niis};
end




if nargin < 2 || isempty(fout)
    fout = 'myscans.gif';
end

if nargin < 3 || isempty(vols)
    vols = ones(numel(niis),1);
end

% if single nii, must have a vols input
if numel(niis)==1 && numel(vols)==1
    error('preproc_mFiles:compare_scans:invalidInput','If a single file is provided, must provide multiple volumes');
end

if numel(niis)~=1 && ~( numel(vols)==1 || numel(vols)==numel(niis) )
    error('preproc_mFiles:compare_scans:invalidInput','Incompatible number of nii files (%i) and volumes; either one must be single, or both must match',numel(niis),numel(vols));
end

% load niis if necessary, limit to chosen volume
if isstruct(niis)
    loaded_niis = niis; clear niis;
else
    for nn = 1:numel(niis)
        loaded_niis(nn) = niftiRead(niis{nn});
    end
    clear niis; % clear so we don't double-up on memory
end





if nargin < 4 || isempty(coords)
    vol2 = 1;
end

if nargin < 5 || isempty(coords)
%    coords = [];
    coords = round(size(nii1.data)/2);

end

if nargin < 6 || isempty(clims)
    clims = repmat([min(min(double(nii1.data(:))),min(double(nii2.data(:)))) max(max(double(nii1.data(:))),max(double(nii2.data(:))))],2,1);
end



% if we want to comapre different contrasts, etc
if ~isnumeric(clims)
    if strcmpi(clims,'each')
        clims = [min(double(nii1.data(:))) max(double(nii1.data(:))); min(double(nii2.data(:))) max(double(nii2.data(:)))]; 
    end

else
    if numel(clims)==2
        clims = repmat(reshape(clims,1,2),2,1);
    end
    
end


%figure;

f1=niftiPlotSlices(nii1,coords,vol1);
set(get(gcf,'Children'),'CLim',clims(1,:));
colormap gray;
set(gcf,'Position',[571         939        1428         389]);
this_frame = getframe(f1);

im = frame2im(this_frame);
[imind,cm] = rgb2ind(im,256);

%close(f1);

% write first file
imwrite(imind,cm,fout,'gif', 'Loopcount',inf); 


f2=niftiPlotSlices(nii2,coords,vol2);
set(get(gcf,'Children'),'CLim',clims(2,:));
set(gcf,'Position',[571         939        1428         389]);
colormap gray;
this_frame = getframe(f2);
%close(f2);


im = frame2im(this_frame);
[imind,cm] = rgb2ind(im,256);


imwrite(imind,cm,fout,'gif','WriteMode','append'); 




return



% 
% h = figure;
% axis tight manual % this ensures that getframe() returns a consistent size
% filename = 'testAnimated.gif';
% for n = 1:0.5:5
%     % Draw plot for y = x.^n
%     x = 0:0.01:1;
%     y = x.^n;
%     plot(x,y) 
%     drawnow 
%       % Capture the plot as an image 
%       frame = getframe(h); 
%       im = frame2im(frame); 
%       [imind,cm] = rgb2ind(im,256); 
%       % Write to the GIF File 
%       if n == 1 
%           imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
%       else 
%           imwrite(imind,cm,filename,'gif','WriteMode','append'); 
%       end 
%   end