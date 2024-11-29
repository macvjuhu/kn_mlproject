
import os
import sys
import pandas as pd
from sklearn.model_selection import train_test_split
from common.logger import logging as logger
from common.exception import CustomException
from components.data_transformation import DataTransformation
from components.model_trainer import ModelTrainer


class DataIngestionConfig:
    test_data_path = "artifacts/test_data.csv"
    train_data_path = "artifacts/train_data.csv"
    raw_data_path = "artifacts/raw_data.csv"
    original_data_path = "src/notebooks/data/stud.csv"

class DataIngestion:

    def __init__(self):
        self.data_ingestion_config = DataIngestionConfig()

    def initiate_data_ingestion(self):
        try:
            logger.info("Initiating data ingestion")
            os.makedirs(os.path.dirname(self.data_ingestion_config.raw_data_path), exist_ok=True)
            logger.info("Reading data from csv files")
            raw_data = pd.read_csv(self.data_ingestion_config.original_data_path)
            logger.info("Data read successfully")
            raw_data.to_csv(self.data_ingestion_config.raw_data_path, index=False)
            logger.info("Initiating train test split ...")  
            test_data, train_data = train_test_split(raw_data, train_size=0.2, random_state=42)
            logger.info("Train test split completed")
            test_data.to_csv(self.data_ingestion_config.test_data_path, index=False)
            train_data.to_csv(self.data_ingestion_config.train_data_path, index=False)

            logger.info("Data ingestion completed")
            return train_data, test_data, raw_data

        except Exception as e:
            raise CustomException(e, sys)
        
if __name__ == "__main__":
    data_ingestion = DataIngestion()
    train_data, test_data, raw_data = data_ingestion.initiate_data_ingestion()
    # print head of each dataframe
    print(train_data, test_data, raw_data)

    data_transformation = DataTransformation()
    train_arr,test_arr,_ = data_transformation.initiate_data_transformation(train_data,test_data)

    #print(train_arr, test_arr)
    
    modeltrainer = ModelTrainer()
    print(modeltrainer.initiate_model_trainer(train_arr,test_arr))

