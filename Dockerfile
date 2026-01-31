FROM runpod/ai-assistant-comfyui:latest

WORKDIR /comfyui/models

# Correction : Ajout des && \ pour lier toutes les lignes de téléchargement
RUN wget -O unet/z_image_turbo_bf16.safetensors "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors" && \
    wget -O clip/qwen_3_4b.safetensors "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors" && \
    wget -O loras/RealisticSnapshot-Zimage-Turbov5.safetensors "https://civitai.com/api/download/models/2867257?token=69dccb6698cfa66bc7bff0c1771619ff" && \
    wget -O vae/ae.safetensors "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors"

RUN cd /comfyui/custom_nodes && git clone https://github.com/ltdrdata/ComfyUI-Manager.git

COPY handler.py /comfyui/handler.py

WORKDIR /comfyui

# On s'assure que ComfyUI et le handler se lancent
CMD python3 main.py --listen 127.0.0.1 --port 8188 & python3 -u /comfyui/handler.py