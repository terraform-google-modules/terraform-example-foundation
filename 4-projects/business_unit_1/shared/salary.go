package main

import (
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"time"

	"cloud.google.com/go/logging"
	"cloud.google.com/go/storage"
	"google.golang.org/api/option"
)

const (
	serviceAccountToImpersonate = "CONFIDENTIAL-SPACCE-WORKLOAD-SERVICE-ACCOUNT"
	projectID                   = "CONFIDENTIAL-SPACE-PROJECT"
	bucketName                  = "CONFIDENTIAL-SPACE-BUCKET"
)

func main() {
	ctx := context.Background()

	fileName := "salary.txt"

	err := ioutil.WriteFile(fileName, []byte("test\n"), 0644)
	if err != nil {
		log.Fatalf("Error creating file: %v", err)
	}
	fmt.Println("Script success!")

	storageClient, err := storage.NewClient(ctx, option.ImpersonateCredentials(serviceAccountToImpersonate))
	if err != nil {
		log.Fatalf("Error creating storage client: %v", err)
	}
	defer storageClient.Close()

	err = uploadToGCS(ctx, storageClient, fileName, bucketName, fileName)
	if err != nil {
		log.Fatalf("Error sending file to GCS: %v", err)
	}
	fmt.Println("Success sendign file to GCS!")

	err = writeLogEntry(ctx, projectID, "confidential_log", "Log created by Confidential space instance.", logging.Info)
	if err != nil {
		log.Fatalf("Error writing log: %v", err)
	}
	fmt.Println("Log sent!")
}

func uploadToGCS(ctx context.Context, client *storage.Client, filePath, bucket, object string) error {
	f, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("error opening the file: %w", err)
	}
	defer f.Close()

	data, err := ioutil.ReadAll(f)
	if err != nil {
		return fmt.Errorf("error reading the file: %w", err)
	}
	f.Seek(0, 0)

	wc := client.Bucket(bucket).Object(object).NewWriter(ctx)
	if _, err := wc.Write(data); err != nil {
		return fmt.Errorf("error writing into bucket: %w", err)
	}
	if err := wc.Close(); err != nil {
		return fmt.Errorf("error closing writer: %w", err)
	}
	return nil
}

func writeLogEntry(ctx context.Context, projectID, logID, message string, severity logging.Severity) error {
	client, err := logging.NewClient(ctx, projectID, option.ImpersonateCredentials(serviceAccountToImpersonate))
	if err != nil {
		return fmt.Errorf("erro creating logging client: %w", err)
	}
	defer client.Close()

	logger := client.Logger(logID)

	logger.Log(logging.Entry{
		Severity:  severity,
		Payload:   message,
		Timestamp: time.Now(),
	})

	return nil
}

