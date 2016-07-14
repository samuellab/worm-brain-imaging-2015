function d = get_displacement()
% gets a displacement between two points in feature_annotator

    p1 = get_point;
    p2 = get_point;

    d = p2-p1;

end