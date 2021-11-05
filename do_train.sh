#/bin/sh

# Arguments
# $1 : 0 or 1 indicating if train/eval lstm files generation is skipped (usfull for re-training)
# $2 : psm mode for lstm files creation
# $3 : N number of maximum train steps 

default_psm=11
default_train_steps=10000

# Convert samples to lstm files and create file list
python3 convert2lstm.py -n train_data -i train_samples -p ${2:-$default_psm} -d ${1:-0}
python3 convert2lstm.py -n eval_data -i validation_samples -p ${2:-$default_psm} -d ${1:-0} 



# Extract checkpoin model
combine_tessdata -e /usr/share/tesseract-ocr/5/tessdata/eng.traineddata lstm_model/eng.lstm

# Execute training loop
mkdir output/training_checkpoints
lstmtraining 	--model_output output/training_checkpoints/fine_tuned \
		        --continue_from lstm_model/eng.lstm \
				--traineddata /usr/share/tesseract-ocr/5/tessdata/eng.traineddata \
				--train_listfile train_data.txt \
				--eval_listfile eval_data.txt \
				--max_iterations ${3:-$default_train_steps}
		
# Get trained model 
lstmtraining    --stop_training \
                --continue_from output/training_checkpoints/fine_tuned_checkpoint \
				--traineddata /usr/share/tesseract-ocr/5/tessdata/eng.traineddata \
				--model_output output/eng_fine_tuned.traineddata

# lstmtraining --help	
# Usage:
#   lstmtraining -v | --version | lstmtraining [.tr files ...] [OPTION ...]

#   --debug_interval  How often to display the alignment.  (type:int default:0)
#   --net_mode  Controls network behavior.  (type:int default:192)
#   --perfect_sample_delay  How many imperfect samples between perfect ones.  (type:int default:0)
#   --max_image_MB  Max memory to use for images.  (type:int default:6000)
#   --append_index  Index in continue_from Network at which to attach the new network defined by net_spec  (type:int default:-1)
#   --max_iterations  If set, exit after this many iterations  (type:int default:0)
#   --debug_level  Level of Trainer debugging  (type:int default:0)
#   --load_images  Load images with tr files  (type:int default:0)
#   --target_error_rate  Final error rate in percent.  (type:double default:0.01)
#   --weight_range  Range of initial random weights.  (type:double default:0.1)
#   --learning_rate  Weight factor for new deltas.  (type:double default:0.001)
#   --momentum  Decay factor for repeating deltas.  (type:double default:0.5)
#   --adam_beta  Decay factor for repeating deltas.  (type:double default:0.999)
#   --clusterconfig_min_samples_fraction  Min number of samples per proto as % of total  (type:double default:0.625)
#   --clusterconfig_max_illegal  Max percentage of samples in a cluster which have more than 1 feature in that cluster  (type:double default:0.05)
#   --clusterconfig_independence  Desired independence between dimensions  (type:double default:1)
#   --clusterconfig_confidence  Desired confidence in prototypes created  (type:double default:1e-06)
#   --reset_learning_rate  Resets all stored learning rates to the value specified by --learning_rate.  (type:bool default:false)
#   --debug_float  Raise error on certain float errors.  (type:bool default:false)
#   --stop_training  Just convert the training model to a runtime model.  (type:bool default:false)
#   --convert_to_int  Convert the recognition model to an integer model.  (type:bool default:false)
#   --sequential_training  Use the training files sequentially instead of round-robin.  (type:bool default:false)
#   --debug_network  Get info on distribution of weight values  (type:bool default:false)
#   --randomly_rotate  Train OSD and randomly turn training samples upside-down  (type:bool default:false)
#   --net_spec  Network specification  (type:string default:)
#   --continue_from  Existing model to extend  (type:string default:)
#   --model_output  Basename for output models  (type:string default:lstmtrain)
#   --train_listfile  File listing training files in lstmf training format.  (type:string default:)
#   --eval_listfile  File listing eval files in lstmf training format.  (type:string default:)
#   --traineddata  Combined Dawgs/Unicharset/Recoder for language model  (type:string default:)
#   --old_traineddata  When changing the character set, this specifies the old character set that is to be replaced  (type:string default:)
#   --configfile  File to load more configs from  (type:string default:)
#   --D  Directory to write output files to  (type:string default:)
#   --F  File listing font properties  (type:string default:font_properties)
#   --X  File listing font xheights  (type:string default:)
#   --U  File to load unicharset from  (type:string default:unicharset)
#   --O  File to write unicharset to  (type:string default:)
#   --output_trainer  File to write trainer to  (type:string default:)
#   --test_ch  UTF8 test character string  (type:string default:)
#   --fonts_dir    (type:string default:)
#   --fontconfig_tmpdir    (type:string default:)
