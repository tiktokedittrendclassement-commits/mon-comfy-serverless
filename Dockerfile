FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

# Installation des outils de base
RUN apt-get update && apt-get install -y python3-pip git curl

# Installation de ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /comfyui
WORKDIR /comfyui
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
RUN pip3 install -r requirements.txt runpod requests

# CRÉATION DES DOSSIERS ET TÉLÉCHARGEMENT AVEC CURL (Plus fiable)
WORKDIR /comfyui/models
RUN mkdir -p unet clip loras vae && \
    curl -L -o unet/z_image_turbo_bf16.safetensors "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors" && \
    curl -L -o clip/qwen_3_4b.safetensors "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors" && \
    curl -L -o loras/RealisticSnapshot-Zimage-Turbov5.safetensors "https://civitai-delivery-worker-prod.5ac0637cfd0766c97916cefa3764fbdf.r2.cloudflarestorage.com/model/2867257/realisticsnapshot.sZI5.safetensors?X-Amz-Expires=86400&response-content-disposition=attachment%3B%20filename%3D%22RealisticSnapshot-Zimage-Turbov5.safetensors%22&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=e01358d793ad6966166af8b3064953ad/20260201/us-east-1/s3/aws4_request&X-Amz-Date=20260201T074525Z&X-Amz-SignedHeaders=host&X-Amz-Signature=181985d3f0b5bdd95a1ed3c2ae7210796d465d09fabfea01d5cea5f2c3a3fc69" && \
    curl -L -o vae/ae.safetensors "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors"

# Custom Nodes & Handler
RUN cd /comfyui/custom_nodes && git clone https://github.com/ltdrdata/ComfyUI-Manager.git
COPY handler.py /comfyui/handler.py

WORKDIR /comfyui
CMD python3 main.py --listen 127.0.0.1 --port 8188 & python3 -u /comfyui/handler.py
