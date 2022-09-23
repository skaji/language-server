package language

import (
	"context"
	"io"
	"log"

	"github.com/sourcegraph/jsonrpc2"
)

type Server struct {
	Handler *Handler
	Conn    io.ReadWriteCloser
	Logger  *log.Logger
}

func (s *Server) Run(ctx context.Context) {
	opts := []jsonrpc2.ConnOpt{jsonrpc2.LogMessages(s.Logger)}
	stream := jsonrpc2.NewBufferedStream(s.Conn, jsonrpc2.VSCodeObjectCodec{})
	handler := jsonrpc2.HandlerWithError(s.Handler.Handle)
	conn := jsonrpc2.NewConn(ctx, stream, handler, opts...)
	<-conn.DisconnectNotify()
}
