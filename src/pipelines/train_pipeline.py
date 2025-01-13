from components.data_ingestion import DataIngestion
from components.data_transformation import DataTransformation
from components.model_trainer import ModelTrainer


class TrainPipeline:
    def __init__(self):
        pass

    def train(self):
        # Initiate data ingestion
        data_ingestion = DataIngestion()
        train_data, test_data, _ = data_ingestion.initiate_data_ingestion()
        
        # Initiate data transformation
        data_transformation = DataTransformation()
        train_arr, test_arr, _ = data_transformation.initiate_data_transformation(train_data, test_data)
        
        # Initiate model training
        model_trainer = ModelTrainer()
        r2_score = model_trainer.initiate_model_trainer(train_arr, test_arr)
        print(f'R2 Score: {r2_score}')


trainPipeline = TrainPipeline()
