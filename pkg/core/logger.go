package core

import (
	"github.com/protonbuild/pbcore/pkg/logging"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

func MakeLogger(lvl zapcore.Level) *zap.Logger {


	logger, err :=  logging.NewStackdriverLogging(lvl )
	if err != nil {
		logger = MakeLogger(lvl)
	}

	return logger
}
