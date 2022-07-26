import json
import logging

def lambda_handler(event, context):
    logger = logging.getLogger('com.tuxpuck')
    logger.setLevel('INFO')
    
    logger.info(f'bank event raw: {event}')
    
    for record in event['Records']:
        body = json.loads(record['body'])
        logger.info(f'record: {record}')
        logger.info(f'body json: {body}')
