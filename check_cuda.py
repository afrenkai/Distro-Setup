import torch

def test_torch() -> str:
    """
    """
    if torch.cuda.is_available() == 1:
        return "Cuda detected, yes!"
    else:
        return "No Cuda Detected"
    return "No Cuda Found, defaulting to cpu"

if __name__ == "__main__":
    print(test_torch())
