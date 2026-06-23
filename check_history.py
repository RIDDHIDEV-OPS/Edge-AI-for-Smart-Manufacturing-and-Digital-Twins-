import json

log_path = r'C:\Users\riddh\.gemini\antigravity-ide\brain\99436b84-b654-4427-8bbc-279918e28955\.system_generated\logs\transcript.jsonl'
output = {}

with open(log_path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            data = json.loads(line)
        except: continue
        if 'tool_calls' in data:
            for call in data['tool_calls']:
                if call['name'] in ('replace_file_content', 'multi_replace_file_content', 'write_to_file'):
                    args = call.get('args', {})
                    if 'TargetFile' in args:
                        file_path = args['TargetFile'].lower()
                        if 'aicopilotpage.tsx' in file_path or 'digitaltwinpage.tsx' in file_path:
                            if file_path not in output:
                                output[file_path] = []
                            
                            chunks = args.get('ReplacementChunks', [args])
                            for chunk in chunks:
                                output[file_path].append({
                                    'target': chunk.get('TargetContent'),
                                    'replacement': chunk.get('ReplacementContent')
                                })

with open('d:/TwinMind/history_revert.json', 'w', encoding='utf-8') as out:
    json.dump(output, out, indent=2)
