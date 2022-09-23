package language

import (
	"context"
	"log"

	"github.com/sourcegraph/jsonrpc2"
)

type Handler struct {
	Language *Language
	Logger   *log.Logger
}

func (h *Handler) Handle(ctx context.Context, conn *jsonrpc2.Conn, req *jsonrpc2.Request) (any, error) {
	switch req.Method {
	case "initialize":
	case "initialized":
	case "shutdown":
	case "textDocument/didOpen":
	case "textDocument/didChange":
	case "textDocument/didSave":
	case "textDocument/didClose":
	case "textDocument/formatting":
	case "textDocument/documentSymbol":
	case "textDocument/completion":
	case "textDocument/definition":
	case "textDocument/hover":
	case "textDocument/codeAction":
	case "workspace/executeCommand":
	case "workspace/didChangeConfiguration":
	case "workspace/workspaceFolders":
	}
	return "ok", nil
}
