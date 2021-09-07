package logging

import (
	"cloud.google.com/go/logging"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

func NewStackdriverLogging(level zapcore.Level) (*zap.Logger, error) {
	return zap.Config{
		Level:       zap.NewAtomicLevelAt(level),
		Development: false,
		Sampling: &zap.SamplingConfig{
			Initial:    100,
			Thereafter: 100,
		},
		Encoding: "json",
		EncoderConfig: zapcore.EncoderConfig{
			LevelKey:      "severity",
			NameKey:       "logger",
			CallerKey:     "caller",
			StacktraceKey: "stack_trace",
			TimeKey:       "time",
			MessageKey:    "message",
			LineEnding:    zapcore.DefaultLineEnding,
			EncodeTime:    zapcore.RFC3339NanoTimeEncoder,
			EncodeLevel:   levelEncode,
			EncodeCaller:  zapcore.ShortCallerEncoder,
		},
		OutputPaths:      []string{"stdout"},
		ErrorOutputPaths: []string{"stderr"},
	}.Build()
}

func levelEncode(l zapcore.Level, enc zapcore.PrimitiveArrayEncoder) {
	switch l {
	case zapcore.DebugLevel:
		enc.AppendString(logging.Debug.String())
	case zapcore.InfoLevel:
		enc.AppendString(logging.Info.String())
	case zapcore.WarnLevel:
		enc.AppendString(logging.Warning.String())
	case zapcore.ErrorLevel:
		enc.AppendString(logging.Error.String())
	default:
		enc.AppendString(logging.Critical.String())
	}
}
