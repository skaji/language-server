package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/skaji/language-server"
)

func main() {
	logger := log.New(os.Stderr, "", log.Ldate|log.Ltime|log.Lshortfile)
	server := &language.Server{
		Handler: &language.Handler{
			Language: &language.Language{},
			Logger:   logger,
		},
		Conn:   &language.Stdio{},
		Logger: logger,
	}
	ctx, cancel := signal.NotifyContext(context.Background(), syscall.SIGTERM, syscall.SIGINT)
	defer cancel()

	logger.Println("start, pid", os.Getpid())
	server.Run(ctx)
	logger.Println("finish")
}
