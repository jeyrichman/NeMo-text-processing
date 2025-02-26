#!/bin/bash

# Copyright (c) 2021, NVIDIA CORPORATION.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

MODE=${1:-"interactive"}
LANGUAGE=${2:-"en"}
INPUT_CASE=${3:-"lower_cased"}
SCRIPT_DIR=$(cd $(dirname $0); pwd)
GRAMMAR_DIR=${4:-${SCRIPT_DIR}"/.."}

: ${CLASSIFY_DIR:="$GRAMMAR_DIR/$LANGUAGE/classify"}
: ${VERBALIZE_DIR:="$GRAMMAR_DIR/$LANGUAGE/verbalize"}
: ${CMD:=${5:-"/bin/bash"}}

MOUNTS=""
MOUNTS+=" -v $CLASSIFY_DIR:/workspace/sparrowhawk/documentation/grammars/en_toy/classify"
MOUNTS+=" -v $VERBALIZE_DIR:/workspace/sparrowhawk/documentation/grammars/en_toy/verbalize"

WORK_DIR="/workspace/sparrowhawk/documentation/grammars"

# update test case script based on input case (for ITN English)
if [[ $INPUT_CASE == "lower_cased" ]]; then
  INPUT_CASE=".sh"
else
  INPUT_CASE="_cased.sh"
fi

if [[ $MODE == "test_tn_grammars" ]]; then
  CMD="bash test_sparrowhawk_normalization.sh"
  WORK_DIR="/workspace/tests/${LANGUAGE}"
elif [[ $MODE == "test_itn_grammars" ]]; then
  CMD="bash test_sparrowhawk_inverse_text_normalization${INPUT_CASE}"
  WORK_DIR="/workspace/tests/${LANGUAGE}"
fi

echo $MOUNTS
docker run -it --rm \
  --shm-size=4g \
  --ulimit memlock=-1 \
  --ulimit stack=67108864 \
  $MOUNTS \
  -v $SCRIPT_DIR/../../../tests/nemo_text_processing/:/workspace/tests/ \
  -w $WORK_DIR \
  sparrowhawk:latest $CMD