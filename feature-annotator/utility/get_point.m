function p = get_point(prompt)
% Gets a point (y,x,(z),t) from the active volume in feature_annotator

global feature_annotator_data;

figure(feature_annotator_data.gui.figure1);

if nargin == 0 
    prompt = 'Select a point';
end

feature_annotator_callbacks('wait_for_selection', ...
                            [prompt ':  choose T and Z, then hit "s"']);

%store the current select instructions string
temp =  get(feature_annotator_data.gui.select_instructions, 'String');

set(feature_annotator_data.gui.select_instructions, 'String',  ...
    ['Select a point, then hit ENTER']);


[X, Y] = getpts(feature_annotator_data.gui.axes1);


if isempty(X)
    p = [];
    return;
end

p = [Y(1) X(1)];

if feature_annotator_data.size_Z > 1
    p(3) = feature_annotator_data.z;
end

% restore instructions
set(feature_annotator_data.gui.select_instructions, 'String',  ...
        temp);