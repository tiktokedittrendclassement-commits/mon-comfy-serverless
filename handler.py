import runpod
import requests
import time
import base64
import os

def wait_for_comfyui():
    while True:
        try:
            response = requests.get("http://127.0.0.1:8188/history")
            if response.status_code == 200:
                break
        except:
            time.sleep(1)

def handler(event):
    workflow = event['input']['workflow']
    
    # Envoyer le prompt
    prompt_id = requests.post("http://127.0.0.1:8188/prompt", json={"prompt": workflow}).json().get('prompt_id')

    # Attendre la fin du rendu
    while True:
        history_resp = requests.get(f"http://127.0.0.1:8188/history/{prompt_id}").json()
        if prompt_id in history_resp:
            # On récupère le nom du fichier image généré par le node "5"
            outputs = history_resp[prompt_id]['outputs']
            for node_id in outputs:
                if 'images' in outputs[node_id]:
                    filename = outputs[node_id]['images'][0]['filename']
                    # On lit le fichier sur le disque
                    with open(f"/comfyui/output/{filename}", "rb") as image_file:
                        encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
                    return {"image": encoded_string}
        time.sleep(1)

if __name__ == "__main__":
    wait_for_comfyui()
    runpod.serverless.start({"handler": handler})