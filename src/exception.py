import sys
from src.logger import logging


def error_message_detail(error, error_detail:sys):
    _,_,exc_tb = error_detail.exc_info()
    error_message = "Error occurred at line number: " + str(exc_tb.tb_lineno) + " in " + exc_tb.tb_frame.f_code.co_filename + " : " + str(error)
    return error_message

class CustomException(  Exception):
    def __init__(self, error, error_detail:sys):
        self.error = error
        self.error_detail = error_detail
        self.error_message = error_message_detail(error, error_detail)
        super().__init__(self.error_message)
        
    def __str__(self):
        return self.error_message
    