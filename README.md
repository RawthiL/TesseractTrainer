# Simple Tesseract 5.0 Training Docker

This image contains the bare minimum code to train the `tesseract 5.0` lstm English model. The training requires:

- **Train_data**: A folder with the train dataset composed of `.tiff` images and their corresponding `.box` files.

- **Validation_data**: A folder with the validation dataset composed of `.tiff` images and their corresponding `.box` files.


### Build and train

To build the image just do:
- `docker build --build-arg UBUNTU_VERSION=20.04  -t tesseract_trainer:5.0  .`

To fine tune your data execute:
- ```
        docker run -u $UID:$UID \ 
                -v <host path to "Train_data">:/home/tesstrain/train_samples \   
                -v <host path to "Validation_data">:/home/tesstrain/validation_samples \
                -v <host path to output directory>:/home/tesstrain/output   \ 
                -it tesseract_trainer:5.0 \ 
                                        <"0" to process all .tiff and .box into .lstm or "1" to skip this if already done> \ 
                                        <The psm mode (default is 7) to detect text>\ 
                                        <Number of train iterations>
    ```

For example in linux:

`docker run -u $UID:$UID -v /foo/bar/train_samples:/home/tesstrain/train_samples -v /foo/bar/validation_samples:/home/tesstrain/validation_samples -v /foo/bar/output:/home/tesstrain/output -it tesseract_trainer:5.0 0 7 10000`

This will process the `.tiff` and `.box` files to generate the `.lstm` files using `psm=7` and then train the best English model for 10000 iterations.


### TODO

- Add example data with VIA.
- Add language selector.
- Add script to convert `VIA` box coordinates to `.box` files.
- Add more training parameters configuration.
