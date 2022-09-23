package language

import "os"

type Stdio struct{}

func (s *Stdio) Read(p []byte) (int, error) {
	return os.Stdin.Read(p)
}

func (s *Stdio) Write(p []byte) (int, error) {
	return os.Stdout.Write(p)
}

func (s *Stdio) Close() error {
	err1 := os.Stdin.Close()
	err2 := os.Stdout.Close()
	if err1 != nil {
		return err1
	}
	return err2
}
