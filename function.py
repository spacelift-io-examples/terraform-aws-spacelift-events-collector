import boto3
import hashlib
import hmac
import json
import os

def is_signature_valid(headers, payload, secret):
  signature = hmac.new(secret.encode("UTF-8"), payload.encode("UTF-8"), hashlib.sha256).hexdigest()
  return hmac.compare_digest(f"sha256={signature}", headers["x-signature-256"])

def handler(event, context):
  if os.getenv("VERBOSE") == "true":
    print("Received event: " + json.dumps(event, indent=2))

  if not is_signature_valid(
    headers=event["headers"],
    payload=event["body"],
    secret=os.getenv("SECRET", ""),
  ):
    print("Error: Invalid signature (401)")
    return {
      "body": json.dumps("Invalid signature"),
      "statusCode": 401
    }

  client = boto3.client("firehose")
  response = client.put_record(
    DeliveryStreamName=os.getenv("STREAM"),
    Record={
        "Data": event["body"] + "\n"
    }
  )
  if os.getenv("VERBOSE") == "true":
    print("Response: " + json.dumps(response, indent=2))

  print("Success: Ok (200)")
  return {
      "body": json.dumps("Ok"),
      "statusCode": 200
  }
