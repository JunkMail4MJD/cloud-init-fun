# This is the directory where vmdk files go.

VBox 6 and above changes behavior where a VMDK can only be imported once and then throws an error if you use it again. 

The download-common-images.sh script downloads the VMDK cloud-images and converts them to native VDI virtual box images.

VBox (VDI) images can be imported / cloned any number of times without error.