feature-annotator
=================

Identify and track features in 2- and 3- dimensional time series.

Save images using one TIF file per time point.  All files should be in a the same folder.  The file should be a TIF stack if you're working with a volume series.
The utility `convert_ND2_to_TIF('filename')` can extract ND2 files into the required format.

Once this is done, run `feature_annotator` and start identifying features.
