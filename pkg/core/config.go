package core

import (
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

type Config struct {
	ProjectId string
	ServiceName string

	Storage *Storage

	Logger *zap.Logger

}


func MakeConfig(projectId, serviceName, bucketName string, lvl zapcore.Level) *Config {
	return &Config{
		ProjectId:   projectId,
		ServiceName: serviceName,
		Storage:     SetupStorage(bucketName),
		Logger:      MakeLogger(lvl),
	}
}
