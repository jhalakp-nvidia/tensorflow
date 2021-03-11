## Build Tensorflow with custom TRT build

* Launch container (You would need to change TRT build path)
    ```bash start_tf2_release_container.sh```

* Setup env (You would need to change TRT build path)
    ```source trt_env_setup.sh```

* Build
    ```bash rebuild_tf.sh```

* Debugging TF and TRT source code can be found [here](https://docs.google.com/document/d/1ptzihxCeYg0nDsFHUpI5E5i-fgUpAeu0UeiRj75zGNU/edit?usp=sharing)