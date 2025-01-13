import sys
sys.path.append("./src")    
print(sys.path)

from pipelines.train_pipeline import TrainPipeline


if __name__=="__main__":
    trainPipeline = TrainPipeline()
    trainPipeline.train()

