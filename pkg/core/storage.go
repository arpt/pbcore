package core

import (
	"cloud.google.com/go/storage"
	"context"
	"log"
)


type Storage struct {
	Client *storage.Client
	BucketName string
}

func CreateClient() *storage.Client {
	ctx := context.Background()

	client, err := storage.NewClient(ctx)
	if err != nil {
		log.Fatalln("GCP Client Error", err )
	}

	return client
}

func SetupStorage(bucketName string ) *Storage {
	return &Storage{
		Client:     CreateClient(),
		BucketName: bucketName,
	}
}