#!/bin/bash

CTAGS=`which ctags`
TAGFILE=/tmp/ctags_otb.txt
OTBSRC=$HOME/Projets/otb/src/OTB

cd $OTBSRC

$CTAGS -f $TAGFILE --fields=fkstia --c++-kinds=+p  -R  Code
#$CTAGS -f $TAGFILE --fields=fkstia  --c++-kinds=+p -R  Utilities/ITK/Code

function check_method {

echo "Checking $1 (should be $2 and is not)"
cat $TAGFILE | grep "^$1	" | grep "access" | grep -v "access:$2" | cut -f 2
echo

}


# ProcessObject public virtual methods
check_method GetNumberOfValidRequiredInputs public
check_method Update public
check_method UpdateLargestPossibleRegion public
check_method UpdateOutputInformation public
check_method PropagateRequestedRegion public
check_method UpdateOutputData public
check_method EnlargeOutputRequestedRegion public
check_method ResetPipeline public
check_method MakeOutput public
check_method SetReleaseDataFlag public
check_method GetReleaseDataFlag public
check_method PrepareOutputs public

# ProcessObject protected virtual methods
check_method SetNthInput protected
check_method AddInput protected
check_method RemoveInput protected
#check_method PushBackInput protected
#check_method PopBackInput protected
#check_method PushFrontInput protected
#check_method PopFrontInput protected
check_method SetNthOutput protected
check_method SetNthOutput protected
check_method AddOutput protected
check_method RemoveOutput protected
check_method GenerateInputRequestedRegion protected
check_method GenerateOutputRequestedRegion protected
check_method GenerateOutputInformation protected
check_method GenerateData protected
check_method PropagateResetPipeline protected
check_method ReleaseInputs protected
check_method CacheInputReleaseDataFlags protected
check_method RestoreInputReleaseDataFlags protected

# LightObject protected virtual methods
check_method PrintSelf protected

# ImageSource protected virtual methods
check_method ThreadedGenerateData protected
check_method AllocateOutputs protected
check_method BeforeThreadedGenerateData protected
check_method AfterThreadedGenerateData protected
check_method SplitRequestedRegion protected


