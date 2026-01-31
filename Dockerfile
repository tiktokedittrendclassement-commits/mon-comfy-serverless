FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

# Installation des outils de base
RUN apt-get update && apt-get install -y python3-pip git wget

# Installation de ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /comfyui
WORKDIR /comfyui
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
RUN pip3 install -r requirements.txt runpod requests

# CRÉATION DES DOSSIERS ET TÉLÉCHARGEMENT AVEC OPTIONS ROBUSTES
WORKDIR /comfyui/models
RUN mkdir -p unet clip loras vae && \
    wget -qL -O unet/z_image_turbo_bf16.safetensors "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors" && \
    wget -qL -O clip/qwen_3_4b.safetensors "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors" && \
    wget -qL -O loras/RealisticSnapshot-Zimage-Turbov5.safetensors "https://civitai.com/api/download/models/2867257?token=69dccb6698cfa66bc7bff0c1771619ff" && \
    wget -qL -O vae/ae.safetensors "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors"

# Custom Nodes & Handler
RUN cd /comfyui/custom_nodes && git clone https://github.com/ltdrdata/ComfyUI-Manager.git
COPY handler.py /comfyui/handler.py

WORKDIR /comfyui
CMD python3 main.py --listen 127.0.0.1 --port 8188 & python3 -u /comfyui/handler.py
