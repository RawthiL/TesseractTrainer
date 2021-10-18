#/bin/sh

# Arguments
# $1 : 0 or 1 indicating if train/eval lstm files generation is skipped (usfull for re-training)
# $2 : psm mode for lstm files creation
# $3 : N number of maximum train steps 


# Convert samples to lstm files and create file list
python3 convert2lstm.py -n train_data -i train_samples -p ${2:-7} -d ${1:-0}
python3 convert2lstm.py -n eval_data -i validation_samples -p ${2:-7} -d ${1:-0} 



# Extract checkpoin model
combine_tessdata -e /usr/share/tesseract-ocr/5/tessdata/eng.traineddata lstm_model/eng.lstm

# Execute training loop
lstmtraining 	--model_output output/fine_tuned \
		--continue_from lstm_model/eng.lstm \
		--traineddata /usr/share/tesseract-ocr/5/tessdata/eng.traineddata \
		--train_listfile train_data.txt \
		--eval_listfile eval_data.txt \
		--max_iterations ${3:-400}
