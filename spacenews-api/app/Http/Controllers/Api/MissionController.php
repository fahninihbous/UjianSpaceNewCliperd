<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mission;
use Illuminate\Http\Request;

class MissionController extends Controller
{
    public function index()
    {
        return response()->json(Mission::where('user_id', auth()->id())->latest()->get());
    }

    public function store(Request $request)
    {
        $request->validate(['name' => 'required|string|max:255']);
        $mission = Mission::create([
            'user_id' => auth()->id(),
            'name' => $request->name,
        ]);
        return response()->json($mission, 201);
    }

    public function update(Request $request, $id)
    {
        $mission = Mission::where('user_id', auth()->id())->findOrFail($id);
        $request->validate(['name' => 'required|string|max:255']);
        $mission->update(['name' => $request->name]);
        return response()->json($mission);
    }

    public function destroy($id)
    {
        $mission = Mission::where('user_id', auth()->id())->findOrFail($id);
        $mission->delete();
        return response()->json(['message' => 'Kategori misi dihapus']);
    }
}