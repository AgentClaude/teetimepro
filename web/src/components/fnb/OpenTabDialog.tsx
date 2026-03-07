import { useState } from 'react';
import { Modal } from '../ui/Modal';
import { Button } from '../ui/Button';
import { Input } from '../ui/Input';

interface Course {
  id: string;
  name: string;
}

interface OpenTabDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: { golferName: string; courseId: string }) => void;
  courses: Course[];
  loading?: boolean;
}

export const OpenTabDialog: React.FC<OpenTabDialogProps> = ({
  isOpen,
  onClose,
  onSubmit,
  courses,
  loading = false,
}) => {
  const [golferName, setGolferName] = useState('');
  const [courseId, setCourseId] = useState('');
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    const newErrors: Record<string, string> = {};
    
    if (!golferName.trim()) {
      newErrors.golferName = 'Golfer name is required';
    }
    
    if (!courseId) {
      newErrors.courseId = 'Course selection is required';
    }
    
    setErrors(newErrors);
    
    if (Object.keys(newErrors).length === 0) {
      onSubmit({
        golferName: golferName.trim(),
        courseId,
      });
      
      // Reset form
      setGolferName('');
      setCourseId('');
      setErrors({});
    }
  };

  const handleClose = () => {
    setGolferName('');
    setCourseId('');
    setErrors({});
    onClose();
  };

  return (
    <Modal isOpen={isOpen} onClose={handleClose} title="Open New F&B Tab" size="md">
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <Input
            id="golferName"
            label="Golfer Name"
            type="text"
            value={golferName}
            onChange={(e) => setGolferName(e.target.value)}
            placeholder="Enter golfer's name"
            error={errors.golferName}
            disabled={loading}
            autoFocus
          />
        </div>

        <div>
          <label
            htmlFor="courseId"
            className="block text-sm font-medium text-gray-700 mb-1"
          >
            Course
          </label>
          <select
            id="courseId"
            value={courseId}
            onChange={(e) => setCourseId(e.target.value)}
            className={`
              w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm 
              focus:outline-none focus:ring-blue-500 focus:border-blue-500
              disabled:bg-gray-100 disabled:cursor-not-allowed
              ${errors.courseId ? 'border-red-500' : ''}
            `}
            disabled={loading}
          >
            <option value="">Select a course</option>
            {courses.map((course) => (
              <option key={course.id} value={course.id}>
                {course.name}
              </option>
            ))}
          </select>
          {errors.courseId && (
            <p className="mt-1 text-sm text-red-600">{errors.courseId}</p>
          )}
        </div>

        <div className="flex justify-end gap-3 pt-4">
          <Button
            type="button"
            variant="outline"
            onClick={handleClose}
            disabled={loading}
          >
            Cancel
          </Button>
          <Button
            type="submit"
            variant="primary"
            disabled={loading}
          >
            {loading ? 'Opening...' : 'Open Tab'}
          </Button>
        </div>
      </form>
    </Modal>
  );
};
